import 'package:flutter/material.dart';
import '../../../domain/entities/article.dart';

class RecentNewsWidget extends StatelessWidget {
  final List<ArticleEntity> articles;

  const RecentNewsWidget({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Text(
          'Recent News',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: articles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final article = articles[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/ArticleDetails',
              arguments: article,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      article.urlToImage ?? 'https://via.placeholder.com/100',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          article.category?.toUpperCase() ?? 'GENERAL',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article.title ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(article.publishedAt?.split('T')[0] ?? 'Today',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12)),
                            const Spacer(),
                            Icon(Icons.share_outlined,
                                size: 18, color: Colors.grey[400])
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      const SizedBox(
          height: 100), // Extra space at bottom for scrolling past navbar
    ]);
  }
}
