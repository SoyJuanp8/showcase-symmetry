import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:like_button/like_button.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/detail/article_detail_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/detail/article_detail_event.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';

class ArticleActionsBar extends StatelessWidget {
  final ArticleEntity article;
  final int selectedIndex;
  final Function(int) onActionSelected;
  final Function(BuildContext, String, {IconData? icon}) onShowSnackBar;

  const ArticleActionsBar({
    super.key,
    required this.article,
    required this.selectedIndex,
    required this.onActionSelected,
    required this.onShowSnackBar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBookmarkAction(context),
            const SizedBox(width: 20),
            _buildActionIcon(
                1, Icons.chat_bubble_outline, Icons.chat_bubble, context),
            const SizedBox(width: 20),
            _buildLikeButton(context),
            const SizedBox(width: 20),
            _buildTextSizeAction(),
            const SizedBox(width: 20),
            _buildActionIcon(4, Icons.share_outlined, Icons.share, context),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkAction(BuildContext context) {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        bool isSaved = false;
        if (state is LocalArticlesDone) {
          isSaved = state.articles!.any((a) => a.title == article.title);
        }

        return GestureDetector(
          onTap: () {
            if (isSaved) {
              context.read<LocalArticleBloc>().add(RemoveArticle(article));
              onShowSnackBar(context, 'Removed from favorites',
                  icon: Icons.bookmark_outline);
            } else {
              context.read<LocalArticleBloc>().add(SaveArticle(article));
              onShowSnackBar(context, 'Saved to favorites',
                  icon: Icons.bookmark);
            }
          },
          child: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_outline,
            color: isSaved ? const Color(0xFF3A4A7D) : Colors.white,
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildLikeButton(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.uid : null;
    final isLiked =
        userId != null && (article.likes?.contains(userId) ?? false);

    return LikeButton(
      size: 24,
      isLiked: isLiked,
      circleColor:
          const CircleColor(start: Color(0xFF3A4A7D), end: Color(0xFF3A4A7D)),
      bubblesColor: const BubblesColor(
          dotPrimaryColor: Color(0xFF3A4A7D), dotSecondaryColor: Colors.orange),
      likeBuilder: (bool liked) {
        return Icon(
          liked ? Icons.favorite : Icons.favorite_outline,
          color: liked ? const Color(0xFF3A4A7D) : Colors.white,
          size: 24,
        );
      },
      onTap: (liked) async {
        if (userId == null) {
          onShowSnackBar(context, 'Sign in to like');
          return liked;
        }
        context.read<ArticleDetailBloc>().add(ToggleLikeArticle(userId));
        return !liked;
      },
      likeCount: article.likes?.length ?? 0,
      countBuilder: (int? count, bool liked, String text) {
        return Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        );
      },
    );
  }

  Widget _buildTextSizeAction() {
    bool isSelected = selectedIndex == 3;
    return GestureDetector(
      onTap: () => onActionSelected(3),
      child: Text(
        'Aa',
        style: TextStyle(
          color: isSelected ? const Color(0xFF3A4A7D) : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildActionIcon(int index, IconData unselectedIcon,
      IconData selectedIcon, BuildContext context) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onActionSelected(index),
      child: Icon(
        isSelected ? selectedIcon : unselectedIcon,
        color: isSelected ? const Color(0xFF3A4A7D) : Colors.white,
        size: 24,
      ),
    );
  }
}
