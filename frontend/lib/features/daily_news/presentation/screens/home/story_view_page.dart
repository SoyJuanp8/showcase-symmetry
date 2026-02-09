import 'package:flutter/material.dart';
import '../../../domain/entities/article.dart';

class StoryViewPage extends StatefulWidget {
  final List<ArticleEntity> articles;
  final int initialIndex;

  const StoryViewPage({
    super.key,
    required this.articles,
    required this.initialIndex,
  });

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;
  double _currentPageValue = 0.0;
  double _percent = 0.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentPageValue = widget.initialIndex.toDouble();
    _pageController = PageController(initialPage: _currentIndex);

    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page ?? 0.0;
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animationController.addListener(() {
      setState(() {
        _percent = _animationController.value;
      });
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextPage();
      }
    });

    _animationController.forward();
  }

  void _nextPage() {
    if (_currentIndex < widget.articles.length - 1) {
      setState(() {
        _currentIndex++;
        _percent = 0.0;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.reset();
      _animationController.forward();
    } else {
      Navigator.pop(context);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _percent = 0.0;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.articles.length,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final article = widget.articles[index];

          // 3D Cube Transition Logic
          final delta = index - _currentPageValue;
          final isLeaving = delta < 0;
          final rotationAngle = delta * (3.14159 / 2); // pi/2 = 90 degrees

          return Transform(
            alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(rotationAngle),
            child: _buildStoryItem(article, index),
          );
        },
      ),
    );
  }

  Widget _buildStoryItem(ArticleEntity article, int index) {
    return GestureDetector(
      onLongPressStart: (_) => _animationController.stop(),
      onLongPressEnd: (_) => _animationController.forward(),
      onTapUp: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 3) {
          // Tap on left side -> Previous Story
          if (_currentIndex > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        } else {
          // Tap on right side -> Next Story
          _nextPage();
        }
      },
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Hero(
              tag: 'story_${article.url ?? article.title ?? ''}_$index',
              child: Image.network(
                article.urlToImage ?? 'https://via.placeholder.com/600',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Top Progress Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _percent,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                          article.urlToImage ??
                              'https://via.placeholder.com/50',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        article.source?.name ?? 'Symmetry',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom Content
          Positioned(
            left: 20,
            right: 20,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // "Swipe Up" / "See More" button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                TextButton(
                  onPressed: () {
                    final tag =
                        'story_${article.url ?? article.title ?? ''}_$_currentIndex';
                    Navigator.pushReplacementNamed(
                      context,
                      '/ArticleDetails',
                      arguments: {
                        'article': article,
                        'heroTag': tag,
                      },
                    );
                  },
                  child: const Text(
                    'PULSA PARA VER MÁS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
