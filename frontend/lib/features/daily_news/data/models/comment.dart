import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    super.id,
    super.userId,
    super.userName,
    super.userAvatar,
    super.text,
    super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'createdAt': createdAt,
    };
  }

  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      text: entity.text,
      createdAt: entity.createdAt,
    );
  }
}
