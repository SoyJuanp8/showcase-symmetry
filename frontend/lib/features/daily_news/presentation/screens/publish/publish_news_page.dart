import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../bloc/article/my_articles/my_articles_bloc.dart';
import '../../bloc/article/my_articles/my_articles_event.dart';
import '../../bloc/article/my_articles/my_articles_state.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

class PublishNewsPage extends StatefulWidget {
  final ArticleEntity? article;
  const PublishNewsPage({super.key, this.article});

  @override
  State<PublishNewsPage> createState() => _PublishNewsPageState();
}

class _PublishNewsPageState extends State<PublishNewsPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _titleController.text = widget.article!.title ?? '';
      _contentController.text = widget.article!.content ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
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
    if (_selectedImage == null && widget.article == null) {
      _showError('Please attach an image');
      return;
    }

    final authState = context.read<AuthBloc>().state;
    String authorName = 'Symmetry Reporter';
    String? userId;
    if (authState is Authenticated) {
      authorName = authState.user.displayName ?? 'Symmetry Reporter';
      userId = authState.user.uid;
    }

    final newArticle = ArticleEntity(
        id: widget.article?.id, // Keep ID for local DB if exists
        firebaseId: widget.article?.firebaseId, // Keep Firebase ID
        author: authorName,
        userId: userId,
        title: _titleController.text.trim(),
        description: _contentController.text.trim().length > 100
            ? '${_contentController.text.trim().substring(0, 100)}...'
            : _contentController.text.trim(),
        content: _contentController.text.trim(),
        category: 'General',
        publishedAt: widget.article?.publishedAt ??
            DateFormat("yyyy-MM-ddTHH:mm:ssZ").format(DateTime.now()),
        urlToImage: widget.article?.urlToImage ?? '',
        url: widget.article?.url ?? '');

    if (widget.article != null) {
      context
          .read<MyArticlesBloc>()
          .add(EditMyArticle(newArticle, imageFile: _selectedImage));
    } else {
      context
          .read<MyArticlesBloc>()
          .add(SaveMyArticle(newArticle, imageFile: _selectedImage));
    }
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
        content: Text(
          'Your news article has been ${widget.article != null ? 'updated' : 'published'} successfully and is now live on Symmetry.',
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
                                isLoading
                                    ? (widget.article != null
                                        ? 'Updating...'
                                        : 'Publishing...')
                                    : (widget.article != null
                                        ? 'Update Article'
                                        : 'Publish Article'),
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
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                            color: Color(0xFFB5B5FF)),
                        const SizedBox(height: 20),
                        Text(
                          widget.article != null
                              ? 'Updating News...'
                              : 'Publishing News...',
                          style: const TextStyle(
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

  Widget _buildImagePicker(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  _selectedImage != null || widget.article?.urlToImage != null
                      ? const Color(0xFFB5B5FF)
                      : Colors.grey.withOpacity(0.2),
              width:
                  _selectedImage != null || widget.article?.urlToImage != null
                      ? 2
                      : 1,
              style: BorderStyle.solid),
          image: _selectedImage != null
              ? DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                  opacity: 0.8,
                )
              : (widget.article?.urlToImage != null &&
                      widget.article!.urlToImage!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(widget.article!.urlToImage!),
                      fit: BoxFit.cover,
                      opacity: 0.8,
                    )
                  : null),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    _selectedImage != null || widget.article?.urlToImage != null
                        ? Colors.green
                        : const Color(0xFFB5B5FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                  _selectedImage != null || widget.article?.urlToImage != null
                      ? Icons.check_rounded
                      : Icons.add_a_photo_rounded,
                  color: _selectedImage != null ||
                          widget.article?.urlToImage != null
                      ? Colors.white
                      : Colors.black,
                  size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedImage != null || widget.article?.urlToImage != null
                  ? 'Image Selected (Tap to Change)'
                  : 'Attach Image from Gallery',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    _selectedImage != null || widget.article?.urlToImage != null
                        ? Colors.white
                        : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
