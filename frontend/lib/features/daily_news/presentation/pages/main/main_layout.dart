import 'package:flutter/material.dart';
import '../../pages/home/my_articles.dart';
import '../../pages/discover/discover_page.dart';
import '../../widgets/organisms/floating_bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MyArticlesPage(),
    const DiscoverPage(),
    const Center(child: Text('Saved Articles')),
    const Center(child: Text('Profile Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
