import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/source.dart';
import 'source.dart';

import 'package:news_app_clean_architecture/features/daily_news/data/models/comment.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    int? id,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
    String? category,
    Source? source,
    String? savedAt,
    String? userId,
    String? firebaseId,
    List<String>? likes,
    List<CommentModel>? comments,
  }) : super(
          id: id,
          author: author,
          title: title,
          description: description,
          url: url,
          urlToImage: urlToImage,
          publishedAt: publishedAt,
          content: content,
          category: category,
          source: source,
          savedAt: savedAt,
          userId: userId,
          firebaseId: firebaseId,
          likes: likes,
          comments: comments,
        );

  factory ArticleModel.fromJson(Map<String, dynamic> map) {
    return ArticleModel(
        author: map['author'] ?? "",
        title: map['title'] ?? "",
        description: map['description'] ?? "",
        url: map['url'] ?? "",
        urlToImage: map['urlToImage'] != null && map['urlToImage'] != ""
            ? map['urlToImage']
            : kDefaultImage,
        publishedAt: map['publishedAt'] ?? "",
        content: map['content'] ?? "",
        category: map['category'] ?? "General",
        source:
            map['source'] != null ? SourceModel.fromJson(map['source']) : null,
        savedAt: map['savedAt'] ?? "",
        userId: map['userId'],
        firebaseId: map['firebaseId']);
  }

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
      category: entity.category,
      source: entity.source,
      savedAt: entity.savedAt,
      userId: entity.userId,
      firebaseId: entity.firebaseId,
      likes: entity.likes,
      comments: entity.comments != null
          ? entity.comments!.map((e) => CommentModel.fromEntity(e)).toList()
          : null,
    );
  }

  factory ArticleModel.fromFirestore(Map<String, dynamic> map, String id) {
    return ArticleModel(
      author: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: map['url'] ?? "",
      urlToImage: map['urlToImage'] ?? kDefaultImage,
      publishedAt: map['publishedAt'] ?? "",
      content: map['content'] ?? "",
      category: map['category'] ?? "Community",
      source: const SourceModel(id: 'community', name: 'Community'),
      userId: map['userId'],
      firebaseId: id,
      likes: map['likes'] != null ? List<String>.from(map['likes']) : [],
      comments: map['comments'] != null
          ? (map['comments'] as List)
              .map((e) => CommentModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'author': author ?? '',
      'title': title ?? '',
      'description': description ?? '',
      'url': url ?? '',
      'urlToImage': urlToImage ?? '',
      'publishedAt': publishedAt ?? '',
      'content': content ?? '',
      'category': category ?? 'Community',
      'userId': userId ?? 'system',
      'likes': likes ?? [],
      'comments':
          comments?.map((e) => (e as CommentModel).toJson()).toList() ?? [],
    };
  }
}
