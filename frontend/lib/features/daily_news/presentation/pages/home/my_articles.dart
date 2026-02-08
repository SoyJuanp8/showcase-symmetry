import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/my_articles/my_articles_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/organisms/article_list.dart';

class MyArticlesPage extends HookWidget {
  const MyArticlesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyArticlesBloc>(
      create: (context) => sl()..add(const GetMyArticles()),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'My Articles',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<MyArticlesBloc, MyArticlesState>(
      builder: (_, state) {
        if (state is MyArticlesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MyArticlesError) {
          return const Center(child: Icon(Icons.refresh));
        }
        if (state is MyArticlesDone) {
          return ArticleList(
            articles: state.articles,
            isRemovable: false,
          );
        }
        return const SizedBox();
      },
    );
  }
}
