import 'package:flutter/material.dart';
import '../../../domain/entities/article.dart';

class TrendyCard extends StatelessWidget {
  final ArticleEntity article;

  const TrendyCard({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              article.urlToImage ?? 'https://via.placeholder.com/400x250',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 160,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image,
                    size: 40, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title ?? 'Untitled',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '5 articles  ·  4,286 reads',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time,
                        size: 14, color: theme.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '12h',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
