import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import '../../bloc/article/my_articles/my_articles_bloc.dart';
import '../../bloc/article/my_articles/my_articles_event.dart';
import '../../bloc/article/my_articles/my_articles_state.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_event.dart';

class PublishNewsPage extends StatefulWidget {
  const PublishNewsPage({super.key});

  @override
  State<PublishNewsPage> createState() => _PublishNewsPageState();
}

class _PublishNewsPageState extends State<PublishNewsPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedCategory = 'Politics';
  bool _hasImage = false;

  final List<String> _categories = [
    'Politics',
    'Sports',
    'Health',
    'Tech',
    'Science'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onPublish() {
    // 1. Validation
    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter a title');
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      _showError('Please enter some content');
      return;
    }
    if (!_hasImage) {
      _showError('Please attach an image');
      return;
    }

    final newArticle = ArticleModel(
        author: 'John Journalist', // Mocked user
        title: _titleController.text.trim(),
        description: _contentController.text.trim().length > 100
            ? '${_contentController.text.trim().substring(0, 100)}...'
            : _contentController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        publishedAt: DateFormat("yyyy-MM-ddTHH:mm:ssZ").format(DateTime.now()),
        urlToImage:
            'https://images.unsplash.com/photo-1504711434969-e33886168f5c?q=80&w=2070&auto=format&fit=crop', // Mock for now, switching to storage later
        url: '');

    context.read<MyArticlesBloc>().add(SaveMyArticle(newArticle));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text('Success!', textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          'Your news article has been published successfully and is now live on Symmetry.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Back to profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A4A7D),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Back to Profile',
                  style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<MyArticlesBloc, MyArticlesState>(
      listener: (context, state) {
        if (state is MyArticlesActionSuccess) {
          _showSuccess();
          // Also refresh the MyArticles list
          context.read<MyArticlesBloc>().add(const GetMyArticles());
          // Refresh the main feed (Daily News)
          context.read<RemoteArticlesBloc>().add(const GetArticles());
        }
        if (state is MyArticlesError) {
          _showError('Failed to publish: ${state.error?.message}');
        }
      },
      child: BlocBuilder<MyArticlesBloc, MyArticlesState>(
        builder: (context, state) {
          final isLoading = state is MyArticlesLoading;

          return Stack(
            children: [
              Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: isDark ? Colors.white : Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    'Publish Article',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
                body: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      _buildSectionLabel('Title'),
                      _buildTextField(
                        controller: _titleController,
                        hint: 'Write your title here...',
                        maxLines: 2,
                        maxLength: 80,
                      ),
                      const SizedBox(height: 24),

                      // Category Selector
                      _buildSectionLabel('Category'),
                      _buildCategoryDropdown(theme),
                      const SizedBox(height: 24),

                      // Image Picker Mock
                      _buildSectionLabel('Feature Image'),
                      _buildImagePicker(theme),
                      const SizedBox(height: 24),

                      // Content Field
                      _buildSectionLabel('Content'),
                      _buildTextField(
                        controller: _contentController,
                        hint: 'Add article here...',
                        maxLines: 10,
                        helperText:
                            'You can use Markdown for subtitles and formatting (# Subtitle, **bold**, etc.)',
                      ),
                      const SizedBox(height: 40),

                      // Publish Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onPublish,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB5B5FF),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.publish_rounded),
                              const SizedBox(width: 12),
                              Text(
                                isLoading ? 'Publishing...' : 'Publish Article',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFB5B5FF)),
                        SizedBox(height: 20),
                        Text(
                          'Publishing News...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3A4A7D),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    String? helperText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
              contentPadding: const EdgeInsets.all(20),
              border: InputBorder.none,
              counterText: "", // Hide default counter to use custom or none
            ),
            onChanged: (val) {
              if (maxLength != null) setState(() {});
            },
          ),
        ),
        if (maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              '${controller.text.length} / $maxLength characters',
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.6)),
            ),
          ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              helperText,
              style:
                  TextStyle(fontSize: 11, color: Colors.grey.withOpacity(0.6)),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF3A4A7D)),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category,
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black87)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() {
          _hasImage = !_hasImage; // Mocking attachment/detachment
        });
      },
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _hasImage
                  ? const Color(0xFFB5B5FF)
                  : Colors.grey.withOpacity(0.2),
              width: _hasImage ? 2 : 1,
              style: BorderStyle.solid),
          image: _hasImage
              ? const DecorationImage(
                  image: NetworkImage(
                      'https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=500&q=60'),
                  fit: BoxFit.cover,
                  opacity: 0.6,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hasImage ? Colors.green : const Color(0xFFB5B5FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                  _hasImage ? Icons.check_rounded : Icons.add_a_photo_rounded,
                  color: _hasImage ? Colors.white : Colors.black,
                  size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              _hasImage
                  ? 'Image Selected (Tap to Change)'
                  : 'Attach Image from Gallery',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _hasImage ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
