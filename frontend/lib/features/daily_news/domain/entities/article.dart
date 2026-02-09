import 'package:equatable/equatable.dart';
import '../../domain/entities/source.dart';
import '../../domain/entities/comment.dart';

class ArticleEntity extends Equatable {
  final int? id;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final String? category;
  final Source? source;
  final String? savedAt;
  final String? userId;
  final String? firebaseId;
  final List<String>? likes; // List of userIds
  final List<CommentEntity>? comments;

  const ArticleEntity({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.category,
    this.source,
    this.savedAt,
    this.userId,
    this.firebaseId,
    this.likes,
    this.comments,
  });

  @override
  List<Object?> get props {
    return [
      id,
      author,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
      category,
      source,
      savedAt,
      userId,
      firebaseId,
      likes,
      comments,
    ];
  }

  ArticleEntity copyWith({
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
    List<CommentEntity>? comments,
  }) {
    return ArticleEntity(
      id: id ?? this.id,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      category: category ?? this.category,
      source: source ?? this.source,
      savedAt: savedAt ?? this.savedAt,
      userId: userId ?? this.userId,
      firebaseId: firebaseId ?? this.firebaseId,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }

  String get socialId {
    if (firebaseId != null) return firebaseId!;
    // Use URL as unique identifier for API articles
    return url?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ??
        'unknown_${title.hashCode}';
  }
}
