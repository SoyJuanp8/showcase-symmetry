import 'package:flutter/material.dart';
import '../../../domain/entities/article.dart';

class TrendyCard extends StatelessWidget {
  final ArticleEntity article;
  final String? heroTag;
  final void Function(ArticleEntity article)? onArticlePressed;

  const TrendyCard({
    super.key,
    required this.article,
    this.heroTag,
    this.onArticlePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Provide default fallback image if URL is missing or invalid
    final imageUrl =
        article.urlToImage != null && article.urlToImage!.isNotEmpty
            ? article.urlToImage!
            : 'https://via.placeholder.com/300x200';

    return GestureDetector(
      onTap: () => onArticlePressed?.call(article),
      child: Container(
        // width: removed for grid compatibility
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16), // Slightly smaller radius
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
            // Image
            Hero(
              tag: heroTag ?? article.url ?? article.title ?? '',
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 120, // Reduced height for grid
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      article.title ?? 'Untitled',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Metadata (Source)
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 12, color: theme.primaryColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            article.source?.name ??
                                article.publishedAt ??
                                'News',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
