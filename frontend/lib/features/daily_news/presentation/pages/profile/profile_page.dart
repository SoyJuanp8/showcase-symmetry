import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_image.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import '../../widgets/molecules/profile_stats.dart';
import '../publish/publish_news_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showArticlesList = false;
  String _profileImageUrl =
      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
  bool _isUploading = false;

  Future<void> _updateProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
    );

    if (image != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        final uploadUseCase = sl<UploadImageUseCase>();
        final path =
            'users/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final url = await uploadUseCase(
            params: UploadImageParams(file: File(image.path), path: path));

        setState(() {
          _profileImageUrl = url;
          _isUploading = false;
        });
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        // Show error snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60), // Increased top spacing
            // Avatar Section
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 120, // Reduced from 220
                    width: 120,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle, // Circular avatar
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(_profileImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: _isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : null,
                  ),
                  GestureDetector(
                    onTap: _updateProfilePicture,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Back Button section removed

            // Name and Role Section (Below image)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  const Text(
                    'Alexi Turner',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work_outline,
                          size: 14, color: Color(0xFF3A4A7D)),
                      const SizedBox(width: 6),
                      Text(
                        'Journalist',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ProfileStats(
                    onTap: () {
                      setState(() {
                        _showArticlesList = !_showArticlesList;
                      });
                    },
                  ),

                  // Expandable Articles List
                  if (_showArticlesList)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recent Articles',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildArticleListItem(
                                'The Future of AI in News', '2 days ago'),
                            _buildArticleListItem(
                                'Global Tech Summits 2026', '5 days ago'),
                            _buildArticleListItem(
                                'Cybersecurity Trends', '1 week ago'),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Publish Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        // Action for publishing
                        _showPublishOptions(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB5B5FF),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Publish News',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleListItem(String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.article_outlined,
              size: 18, color: Color(0xFF3A4A7D)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            date,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showPublishOptions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PublishNewsPage()),
    );
  }
}
