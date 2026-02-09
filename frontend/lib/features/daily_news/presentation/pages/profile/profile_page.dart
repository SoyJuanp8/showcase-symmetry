import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_image.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
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
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return _buildAuthenticatedContent(context, theme, state);
                } else if (state is Unauthenticated) {
                  return _buildUnauthenticatedContent(context, theme);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedContent(
      BuildContext context, ThemeData theme, Authenticated state) {
    return Column(
      children: [
        // Avatar Section
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    width: 2,
                  ),
                  image: DecorationImage(
                    image:
                        NetworkImage(state.user.photoURL ?? _profileImageUrl),
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
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),

        // User Info
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(
                state.user.displayName ?? 'Alexi Turner',
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email_outlined,
                      size: 14, color: Color(0xFF3A4A7D)),
                  const SizedBox(width: 6),
                  Text(
                    state.user.email ?? 'Journalist',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

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
              if (_showArticlesList) _buildRecentArticles(theme),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _showPublishOptions(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5B5FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text('Publish News',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Log Out',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedContent(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.account_circle_outlined,
            size: 120, color: Colors.grey.withOpacity(0.3)),
        const SizedBox(height: 24),
        const Text(
          'Welcome to Symmetry!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Log in to publish news and personalize your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A4A7D),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Log In',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/Register'),
          child: const Text("Don't have an account? Register",
              style: TextStyle(color: Color(0xFF3A4A7D))),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildRecentArticles(ThemeData theme) {
    return Padding(
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
            const Text('Recent Articles',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildArticleListItem('The Future of AI in News', '2 days ago'),
            _buildArticleListItem('Global Tech Summits 2026', '5 days ago'),
            _buildArticleListItem('Cybersecurity Trends', '1 week ago'),
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
