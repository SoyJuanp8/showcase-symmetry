import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../domain/entities/article.dart';
import '../../widgets/molecules/article_header.dart';
import '../../widgets/molecules/font_size_selector.dart';
import '../../widgets/organisms/article_actions_bar.dart';

class ArticleDetailsView extends StatefulWidget {
  final ArticleEntity article;

  const ArticleDetailsView({super.key, required this.article});

  @override
  State<ArticleDetailsView> createState() => _ArticleDetailsViewState();
}

class _ArticleDetailsViewState extends State<ArticleDetailsView> {
  double _bodyFontSize = 18.0;
  int _selectedIndex = -1;

  void _onActionSelected(int index) {
    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = -1;
      } else {
        _selectedIndex = index;
      }
    });

    if (index == 1) _showComments();
    if (index == 4) _handleShare();
  }

  void _onFontSizeChanged(double size) {
    setState(() {
      _bodyFontSize = size;
      _selectedIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final article = widget.article;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 150),
              child: _buildContent(article, theme),
            ),
          ),

          // Molecule: Custom Header
          const Positioned(top: 0, left: 0, right: 0, child: ArticleHeader()),

          // Molecule: Font Size Menu Overlay
          if (_selectedIndex == 3)
            Positioned(
              bottom: 90,
              right: 75,
              child: FontSizeSelector(
                currentSize: _bodyFontSize,
                onSizeSelected: _onFontSizeChanged,
              ),
            ),

          // Organism: Floating Bottom Bar
          Positioned(
            bottom: 30,
            left: 40,
            right: 40,
            child: ArticleActionsBar(
              article: article,
              selectedIndex: _selectedIndex,
              onActionSelected: _onActionSelected,
              onShowSnackBar: _showModernSnackBar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ArticleEntity article, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildMetadata(theme, article),
        const SizedBox(height: 16),
        _buildTitle(theme, article),
        const SizedBox(height: 20),
        _buildDescription(theme, article),
        const SizedBox(height: 24),
        _buildMainImage(article),
        const SizedBox(height: 8),
        _buildImageCaption(theme),
        const SizedBox(height: 32),
        _buildArticleText(article, theme),
      ],
    );
  }

  Widget _buildMetadata(ThemeData theme, ArticleEntity article) {
    return Text(
      'By ${article.author ?? 'Anonymous'}  ·  ${article.publishedAt?.split('T')[0] ?? 'Today'}',
      style: TextStyle(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        fontSize: 14,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, ArticleEntity article) {
    return Text(
      article.title ?? 'Untitled',
      style: theme.textTheme.displayLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        height: 1.2,
      ),
    );
  }

  Widget _buildDescription(ThemeData theme, ArticleEntity article) {
    return Text(
      article.description ?? 'No description available for this article.',
      style: TextStyle(
        fontSize: 16,
        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
        height: 1.5,
      ),
    );
  }

  Widget _buildMainImage(ArticleEntity article) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        article.urlToImage ?? 'https://via.placeholder.com/600',
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 250,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildImageCaption(ThemeData theme) {
    return Center(
      child: Text(
        'Captured for Symmetry News.',
        style: TextStyle(
          fontSize: 12,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildArticleText(ArticleEntity article, ThemeData theme) {
    return MarkdownBody(
      data: article.content ?? 'No content available.',
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyLarge?.copyWith(
          fontSize: _bodyFontSize,
          height: 1.6,
        ),
        h1: theme.textTheme.displayLarge?.copyWith(
          fontSize: _bodyFontSize + 8,
          fontWeight: FontWeight.bold,
        ),
        h2: theme.textTheme.displayLarge?.copyWith(
          fontSize: _bodyFontSize + 4,
          fontWeight: FontWeight.bold,
        ),
        strong: const TextStyle(fontWeight: FontWeight.bold),
        em: const TextStyle(fontStyle: FontStyle.italic),
        listBullet: theme.textTheme.bodyLarge?.copyWith(
          fontSize: _bodyFontSize,
        ),
      ),
    );
  }

  void _showModernSnackBar(BuildContext context, String message,
      {IconData? icon}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 12),
            ],
            Text(
              message,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF3A4A7D),
        elevation: 6,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Comments',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
                child: Center(
                    child: Text('No comments yet. Be the first to opine!'))),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: 20,
                  right: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  suffixIcon: const Icon(Icons.send),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleShare() {
    _showModernSnackBar(context, 'Opening system share...',
        icon: Icons.share_outlined);
  }
}
