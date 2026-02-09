import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/detail/article_detail_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/detail/article_detail_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/detail/article_detail_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';
import 'package:uuid/uuid.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../widgets/molecules/article_header.dart';
import '../../widgets/molecules/font_size_selector.dart';
import '../../widgets/organisms/article_actions_bar.dart';
import '../../widgets/atoms/fade_in_up.dart';

class ArticleDetailsView extends StatefulWidget {
  final ArticleEntity article;
  final String? heroTag;

  const ArticleDetailsView({super.key, required this.article, this.heroTag});

  @override
  State<ArticleDetailsView> createState() => _ArticleDetailsViewState();
}

class _ArticleDetailsViewState extends State<ArticleDetailsView> {
  double _bodyFontSize = 18.0;
  int _selectedIndex = -1;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onActionSelected(int index, BuildContext context) {
    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = -1;
      } else {
        _selectedIndex = index;
      }
    });

    if (index == 1) _showComments(context);
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
    return BlocProvider(
      create: (context) =>
          sl<ArticleDetailBloc>()..add(GetArticleDetail(widget.article)),
      child: Builder(builder: (context) {
        return _buildScaffold(context);
      }),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<ArticleDetailBloc, ArticleDetailState>(
        builder: (context, state) {
          final article = state.article ?? widget.article;

          return Stack(
            children: [
              // Main Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 150),
                  child: _buildContent(article, theme),
                ),
              ),

              // Molecule: Custom Header
              const Positioned(
                  top: 0, left: 0, right: 0, child: ArticleHeader()),

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
                  onActionSelected: (index) =>
                      _onActionSelected(index, context),
                  onShowSnackBar: _showModernSnackBar,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(ArticleEntity article, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: _buildMetadata(theme, article),
        ),
        const SizedBox(height: 16),
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: _buildTitle(theme, article),
        ),
        const SizedBox(height: 20),
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: _buildDescription(theme, article),
        ),
        const SizedBox(height: 24),
        FadeInUp(
          delay: const Duration(milliseconds: 500),
          child: _buildAISummarySection(context, article, theme),
        ),
        const SizedBox(height: 24),
        Hero(
          tag: widget.heroTag ?? article.url ?? article.title ?? '',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              article.urlToImage ?? 'https://via.placeholder.com/600',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image,
                    size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeInUp(
          delay: const Duration(milliseconds: 600),
          child: _buildImageCaption(theme),
        ),
        const SizedBox(height: 32),
        FadeInUp(
          delay: const Duration(milliseconds: 700),
          child: _buildArticleText(article, theme),
        ),
      ],
    );
  }

  // _buildMainImage removed as it's now inline to allow different animation handling if needed,
  // but mostly to keep the structure clean with offsets.

  Widget _buildMetadata(ThemeData theme, ArticleEntity article) {
    return Text(
      'By ${article.author ?? 'Anonymous'}  ·  ${article.publishedAt?.split('T')[0] ?? 'Today'}',
      style: TextStyle(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        fontSize: _bodyFontSize * 0.77, // Scaled from 14
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, ArticleEntity article) {
    return Text(
      article.title ?? 'Untitled',
      style: theme.textTheme.displayLarge?.copyWith(
        fontSize: _bodyFontSize * 1.55, // Scaled from 28
        fontWeight: FontWeight.w900,
        height: 1.2,
      ),
    );
  }

  Widget _buildDescription(ThemeData theme, ArticleEntity article) {
    return Text(
      article.description ?? 'No description available for this article.',
      style: TextStyle(
        fontSize: _bodyFontSize * 0.88, // Scaled from 16
        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
        height: 1.5,
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
    // Check if the content is truncated (common with NewsAPI)
    final isTruncated = article.content?.contains('[+') ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownBody(
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
        ),
        if (isTruncated && article.url != null) ...[
          const SizedBox(height: 32),
          _buildReadMoreButton(article.url!, theme),
        ],
      ],
    );
  }

  Widget _buildAISummarySection(
      BuildContext context, ArticleEntity article, ThemeData theme) {
    return BlocBuilder<ArticleDetailBloc, ArticleDetailState>(
      builder: (context, state) {
        final content = article.content ?? article.description ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.summary == null &&
                !state.isSummarizing &&
                state.summaryError == null)
              _buildAISummaryButton(context, article, theme),
            if (state.isSummarizing)
              _buildLoadingState(theme, 'Gemini is analyzing the news...'),
            if (state.summaryError != null && state.summary == null)
              _buildErrorState(context, article, theme, state.summaryError!),
            if (state.summary != null) ...[
              _buildSummaryCard(state.summary!, theme),
              const SizedBox(height: 16),
              _buildSmartQuestionsSection(context, content, theme, state),
            ],
            if (state.isAskingQuestion)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildLoadingState(theme, 'Gemini is researching...'),
              ),
            if (state.questionAnswer != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildAnswerCard(state.questionAnswer!, theme),
              ),
            if (state.questionError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Error: ${state.questionError}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(ThemeData theme, String message) {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Color(0xFF3A4A7D)),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ArticleEntity article,
      ThemeData theme, String error) {
    return Column(
      children: [
        _buildAISummaryButton(context, article, theme, isRetry: true),
        const SizedBox(height: 8),
        Text(
          'Error: $error',
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSmartQuestionsSection(BuildContext context, String content,
      ThemeData theme, ArticleDetailState state) {
    final questions = [
      {'label': 'Highlights', 'q': 'What are the key takeaways?'},
      {
        'label': 'Figures',
        'q': 'Who are the key people or entities mentioned?'
      },
      {'label': 'Timeline', 'q': 'What is the timeline of events mentioned?'},
      {
        'label': 'Author',
        'q': 'Who wrote or uploaded this news? (Check content/metadata)'
      },
      {'label': 'Refresh', 'q': 'SUMMARIZE'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology_outlined,
                color: Color(0xFF3A4A7D), size: 20),
            const SizedBox(width: 8),
            Text(
              'DIVE DEEPER WITH GEMINI',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: const Color(0xFF3A4A7D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: questions.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(item['label']!),
                  labelStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  onSelected: (_) {
                    if (item['q'] == 'SUMMARIZE') {
                      context
                          .read<ArticleDetailBloc>()
                          .add(GenerateSummary(content));
                    } else {
                      context
                          .read<ArticleDetailBloc>()
                          .add(AskArticleQuestion(item['q']!));
                    }
                  },
                  backgroundColor: theme.scaffoldBackgroundColor,
                  selectedColor: const Color(0xFF3A4A7D).withOpacity(0.1),
                  side: BorderSide(
                      color: const Color(0xFF3A4A7D).withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerCard(String answer, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3A4A7D).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A4A7D).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: isDark ? Colors.amber[300] : const Color(0xFF3A4A7D),
                  size: 20),
              const SizedBox(width: 8),
              Text(
                'Gemini Insights',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF3A4A7D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          MarkdownBody(
            data: answer,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
              ),
              strong: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummaryButton(
      BuildContext context, ArticleEntity article, ThemeData theme,
      {bool isRetry = false}) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          final content = article.content ?? article.description ?? '';
          if (content.isNotEmpty) {
            context.read<ArticleDetailBloc>().add(GenerateSummary(content));
          } else {
            _showModernSnackBar(context, 'No content to summarize');
          }
        },
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text(isRetry ? 'Retry summary' : 'Summarize with AI (Gemini)'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF3A4A7D),
          side: const BorderSide(color: Color(0xFF3A4A7D)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String summary, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3A4A7D).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A4A7D).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: Color(0xFF3A4A7D), size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3A4A7D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadMoreButton(String url, ThemeData theme) {
    return Center(
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF3A4A7D), Color(0xFF2E3B65)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A4A7D).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              try {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  _showModernSnackBar(context, 'Could not open the link');
                }
              } catch (e) {
                _showModernSnackBar(
                    context, 'Error opening link. Try restarting the app.');
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Read Full Story',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.open_in_new, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
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

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<ArticleDetailBloc>(),
        child: BlocBuilder<ArticleDetailBloc, ArticleDetailState>(
          builder: (context, state) {
            final comments = state.article?.comments ?? [];

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
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
                      'Comments (${comments.length})',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: comments.isEmpty
                        ? const Center(
                            child:
                                Text('No comments yet. Be the first to opine!'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: comment.userAvatar != null
                                      ? NetworkImage(comment.userAvatar!)
                                      : null,
                                  child: comment.userAvatar == null
                                      ? Text(comment.userName?[0] ?? '?')
                                      : null,
                                ),
                                title: Text(comment.userName ?? 'Anonymous',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(comment.text ?? ''),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        left: 20,
                        right: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          color: const Color(0xFF3A4A7D),
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              final authState = context.read<AuthBloc>().state;
                              if (authState is Authenticated) {
                                final comment = CommentEntity(
                                  id: const Uuid().v4(),
                                  userId: authState.user.uid,
                                  userName: authState.user.displayName,
                                  userAvatar: authState.user.photoURL,
                                  text: _commentController.text,
                                  createdAt: DateTime.now().toIso8601String(),
                                );
                                context
                                    .read<ArticleDetailBloc>()
                                    .add(AddCommentArticle(comment));
                                _commentController.clear();
                              } else {
                                _showModernSnackBar(
                                    context, 'Sign in to comment');
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleShare() {
    if (widget.article.url != null && widget.article.url!.isNotEmpty) {
      Share.share(
        'Check out this news from Symmetry: ${widget.article.title}\n\n${widget.article.url}',
        subject: widget.article.title,
      );
    } else {
      _showModernSnackBar(context, 'No URL available to share');
    }
  }
}
