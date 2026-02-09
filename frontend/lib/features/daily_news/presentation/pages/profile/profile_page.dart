import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_image.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_profile_photo.dart';
import '../../widgets/molecules/profile_stats.dart';
import '../../widgets/molecules/user_avatar.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/publish/publish_news_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/theme/theme_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/theme/theme_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/theme/theme_state.dart';

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

        // Update Firebase User Profile
        final updateProfilePhoto = sl<UpdateProfilePhotoUseCase>();
        await updateProfilePhoto(params: url);

        // Force AuthBloc to refresh user data
        if (context.mounted) {
          context.read<AuthBloc>().add(
                AuthUserChanged(FirebaseAuth.instance.currentUser),
              );
        }

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
      body: BlocListener<MyArticlesBloc, MyArticlesState>(
        listener: (context, state) {
          if (state is MyArticlesActionSuccess) {
            // Refresh remote articles when a user article is changed (deleted/edited/added)
            context.read<RemoteArticlesBloc>().add(const GetArticles());
          }
        },
        child: SingleChildScrollView(
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
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    UserAvatar(
                      radius: 60,
                      profileImageUrl: state.user.photoURL ?? _profileImageUrl,
                      userName: state.user.displayName,
                      fontSize: 40,
                    ),
                    if (_isUploading)
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.black45, shape: BoxShape.circle),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
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
                state.user.displayName ?? 'News Reader',
                textAlign: TextAlign.center,
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
              const SizedBox(height: 12),
              // Edit Profile Button
              GestureDetector(
                onTap: () =>
                    _showEditProfileDialog(context, state.user.displayName),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.2) ??
                              Colors.grey,
                    ),
                  ),
                  child: Text(
                    'Edit Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                ),
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
                isExpanded: _showArticlesList,
                onTap: () {
                  setState(() {
                    _showArticlesList = !_showArticlesList;
                    if (_showArticlesList) {
                      context.read<MyArticlesBloc>().add(const GetMyArticles());
                    }
                  });
                },
              ),
              if (_showArticlesList) _buildMyArticles(theme),
              const SizedBox(height: 24),

              // Theme Toggle Section
              _buildSettingsSection(context, theme),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _showPublishOptions(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A4A7D),
                    foregroundColor: Colors.white,
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
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  child: const Text('Log Out',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildMyArticles(ThemeData theme) {
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
            BlocBuilder<MyArticlesBloc, MyArticlesState>(
              builder: (context, state) {
                if (state is MyArticlesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MyArticlesDone) {
                  if (state.articles!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                          child:
                              Text("You haven't published any articles yet.")),
                    );
                  }
                  return Column(
                    children: state.articles!.map((article) {
                      return _buildArticleListItem(article);
                    }).toList(),
                  );
                } else if (state is MyArticlesError) {
                  return Text('Error: ${state.error?.message}');
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, String? currentName) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Display Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  context.read<AuthBloc>().add(UpdateUserDisplayName(newName));
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArticleListItem(ArticleEntity article) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.article_outlined,
              size: 18, color: Color(0xFF3A4A7D)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              article.title ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: Colors.blueAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PublishNewsPage(article: article),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 20, color: Colors.redAccent),
            onPressed: () => _confirmDeleteArticle(context, article),
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

  void _confirmDeleteArticle(BuildContext context, ArticleEntity article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Article'),
        content: const Text(
            'Are you sure you want to delete this article? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<MyArticlesBloc>().add(DeleteMyArticle(article));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, ThemeData theme) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state.themeMode == ThemeMode.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.1) ??
                  Colors.grey,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: const Color(0xFF3A4A7D),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Light Theme',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              Switch(
                value: !isDark,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(ToggleTheme());
                },
                activeColor: const Color(0xFF3A4A7D),
              ),
            ],
          ),
        );
      },
    );
  }
}
