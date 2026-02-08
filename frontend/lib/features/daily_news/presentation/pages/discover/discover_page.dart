import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_state.dart';
import '../../widgets/molecules/discover_search_bar.dart';
import '../../widgets/organisms/trendy_news_section.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final List<String> _categories = [
    'All',
    'Tech',
    'Business',
    'Design',
    'Health'
  ];
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Molecule: Search Bar
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: DiscoverSearchBar(),
                  ),
                  const SizedBox(height: 24),

                  // Category Chips (Custom Horizontal Layout)
                  _buildCategoryChips(theme),
                  const SizedBox(height: 32),

                  // Organism: Trendy News
                  if (state is RemoteArticlesDone)
                    TrendyNewsSection(articles: state.articles!)
                  else if (state is RemoteArticlesLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    const Center(child: Text('Check your connection')),

                  const SizedBox(height: 100), // Space for bottom navbar
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(
          _categories.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedCategoryIndex == index
                      ? const Color(0xFF3A4A7D)
                      : theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: _selectedCategoryIndex == index
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight: _selectedCategoryIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
