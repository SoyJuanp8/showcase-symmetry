import 'package:flutter/material.dart';
import '../../pages/home/my_articles.dart';
import '../../pages/discover/discover_page.dart';
import '../../pages/saved/saved_articles.dart';
import '../../pages/profile/profile_page.dart';
import '../../widgets/organisms/floating_bottom_nav_bar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_event.dart';

import '../../bloc/navigation/navigation_bloc.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: _MainLayoutView(),
    );
  }
}

class _MainLayoutView extends StatefulWidget {
  const _MainLayoutView();

  @override
  State<_MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<_MainLayoutView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        final List<Widget> pages = [
          MyArticlesPage(key: state.index == 0 ? UniqueKey() : null),
          BlocProvider<RemoteArticlesBloc>(
            create: (context) =>
                sl<RemoteArticlesBloc>()..add(const GetArticles()),
            child: DiscoverPage(key: state.index == 1 ? UniqueKey() : null),
          ),
          SavedArticlesPage(key: state.index == 2 ? UniqueKey() : null),
          ProfilePage(key: state.index == 3 ? UniqueKey() : null),
        ];

        return Scaffold(
          extendBody: false,
          body: IndexedStack(
            index: state.index,
            children: pages,
          ),
          bottomNavigationBar: FloatingBottomNavBar(
            currentIndex: state.index,
            onTap: (index) {
              context.read<NavigationBloc>().add(NavigationTabChanged(index));
            },
          ),
        );
      },
    );
  }
}
